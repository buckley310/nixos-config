{ config, lib, ... }:
{
  sconfig.profile = "server";
  users.users.root.password = "toor";
}
