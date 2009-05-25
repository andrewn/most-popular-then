ENVS = {
 :development => {
	:base_path => "/tmp/var/www/html/mpi",
	:log_path  => "/tmp/var/app/mpi",
	:log_name  => "runs.log"
  },
  :production => {
	:base_path => "~/apps/mpi",
	:log_path  => "~/apps/mpi",
	:log_name  => "runs.log"
  }
}