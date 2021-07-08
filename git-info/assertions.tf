// Check if Git is installed
module "git_exists" {
  source  = "../command-exists"
  command = "git"
}

// Make sure Git is installed
module "assert_git_exists" {
  source        = "../assert"
  condition     = module.git_exists.exists
  error_message = "'git' command not found. Git must be installed to use the 'git-info' module."
}
