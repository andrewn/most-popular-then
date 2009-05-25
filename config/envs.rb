ENVS = {
 :development => {
	:base_path => "/tmp/var/www/html/mpi",
	:log_path  => "/tmp/var/app/mpi",
	:log_name  => "runs.log"
  },
  :production => {
	:base_path => "/var/www/html/mpi",
	:log_path  => "/var/app/mpi",
	:log_name  => "runs.log"
  }
}