{
  nixpkgs.config = {
    # cudaSupport = true;
    # rocmSupport = true;
  };
  services.ollama = {
    enable = true;
    acceleration = false;
    # acceleration = "cuda";
    # acceleration = "rocm";
  };
}

# ollama run gpt-oss:120b
