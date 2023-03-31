#!/usr/bin/env python3

from json import loads
from os import readlink
from string import ascii_letters, digits
from subprocess import run, PIPE, STDOUT
from sys import argv


def strict_host_key_checking():
    txt = run(["ssh", "-G", "localhost"], stdout=PIPE).stdout
    if "stricthostkeychecking true" not in txt.decode("utf8").splitlines():
        raise RuntimeError("This script requires StrictHostKeyChecking")


def get_deployment():
    return loads(
        run(
            [
                "nix",
                "eval",
                "--json",
                "--apply",
                "builtins.mapAttrs (n: v: v.config.deploy)",
                ".#nixosConfigurations",
            ],
            stdout=PIPE,
            check=True,
        ).stdout
    )


def expand(ln):
    hosts = set()
    for item in ln.split(","):
        if item == "all":
            hosts.update(depl)
        elif item[0] == "@":
            hosts.update(x for x in depl if item[1:] in depl[x]["tags"])
        else:
            hosts.add(item)
    for host in hosts:
        for c in host:
            if not c in (ascii_letters + digits + "-"):
                raise RuntimeError(f"Invalid hostname: {host}")
    return sorted(hosts)


def build_system(name):
    return loads(
        run(
            [
                "nix",
                "build",
                "--no-link",
                "--json",
                f".#nixosConfigurations.{name}.config.system.build.toplevel",
            ],
            stdout=PIPE,
            check=True,
        ).stdout
    )[0]["outputs"]["out"]


def build_all(hosts):
    return dict([x, build_system(x)] for x in hosts)


def apply(goal, hosts):
    for host in hosts:
        print(f"\n\n{goal} on {host}...\n")
        run(
            [
                "nixos-rebuild",
                goal,
                "--use-substitutes",
                "--use-remote-sudo",
                "--target-host",
                host,
                "--flake",
                ".#" + host,
            ],
            check=True,
        )


def check(hosts):
    hostwidth = max(map(len, hosts))
    new_sys = build_all(hosts)
    print("#" * 64)

    for host in hosts:
        current_sys, cur_kernel, boot_kernel = (
            run(
                [
                    "ssh",
                    host,
                    "readlink",
                    "/run/current-system",
                    "/run/current-system/kernel",
                    "/run/booted-system/kernel",
                ],
                stdout=PIPE,
                check=True,
            )
            .stdout.decode("ascii")
            .strip()
            .split("\n")
        )

        reboot_needed = cur_kernel != boot_kernel
        update_needed = current_sys != new_sys[host]

        print(host.rjust(hostwidth + 1), end=" ")

        if not (reboot_needed or update_needed):
            print(icon_good, "[OK]")
            continue

        print(icon_bad, end=" ")
        if update_needed:
            print("[UPDATE REQUIRED]", end=" ")
            if readlink(new_sys[host] + "/kernel") != boot_kernel:
                print("[UPDATE REQUIRES REBOOT]", end=" ")
        if reboot_needed:
            print("[REBOOT REQUIRED]", end=" ")
        print()

    print("#" * 64)


def push(hosts):
    new_sys = build_all(hosts)
    for host in hosts:
        print(f"Pushing to {host}...")
        run(
            [
                "nix",
                "copy",
                new_sys[host],
                "--to",
                "ssh://" + host,
            ],
            check=True,
        )


def rexec(hosts, cmd):
    hostwidth = max(map(len, hosts))
    for host in hosts:
        r = run(["ssh", host, "--"] + cmd, stdout=PIPE, stderr=STDOUT)
        lines = r.stdout.decode("utf8").strip("\n").splitlines()
        print(host.rjust(hostwidth), end=" ")
        print(icon_bad if r.returncode else icon_good, end=" ")
        if len(lines) == 1:
            print(lines[0])
        else:
            print()
            for ln in lines:
                print(" " * hostwidth, ln)


def main():
    op = argv[1]
    hosts = expand(argv[2])
    args = argv[3:]

    if op in ["boot", "switch", "test"]:
        apply(op, hosts)

    elif op == "check":
        check(hosts)

    elif op == "push":
        push(hosts)

    elif op == "exec":
        rexec(hosts, args)

    else:
        print("Invalid op:", op)


icon_bad = "\u274c"
icon_good = "\u2705"
strict_host_key_checking()
depl = get_deployment()
if __name__ == "__main__":
    main()
