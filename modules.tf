
module "dotfiles" {
  count                   = data.coder_workspace.me.start_count
  source                  = "registry.coder.com/modules/dotfiles/coder"
  version                 = ">=1.0.29"
  agent_id                = coder_agent.main.id
  default_dotfiles_uri    = "git@github.com:red-0130/dotfiles.git"
  default_dotfiles_branch = "main"
}

module "code-server" {
  count          = data.coder_workspace.me.start_count
  source         = "registry.coder.com/coder/code-server/coder"
  version        = "1.5.1"
  agent_id       = coder_agent.main.id
  install_prefix = "/home/coder/.local/code-server"
  use_cached     = true
  extensions = [
    "usernamehw.errorlens",
    "esbenp.prettier-vscode",
    "christian-kohler.path-intellisense",
  ]
  settings = {
    "chat.disableAIFeatures" = true,
  }
}
