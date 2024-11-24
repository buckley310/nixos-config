{
  services.ollama = {
    enable = true;
    acceleration = "cuda";
  };
  programs.bash.interactiveShellInit = ''
    alias ai-code='ollama run qwen2.5-coder:14b'
    alias ai-text='ollama run llama3.1:8b'
  '';
}
