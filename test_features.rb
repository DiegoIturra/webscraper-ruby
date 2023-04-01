require 'etc'
require 'concurrent'

def get_number_of_cpus
    puts "Number of CPU cores: #{Etc.nprocessors}"
end

def get_number_of_threads_per_core
    num_cores = Concurrent.processor_count
    hardware_threads_per_core = 2 # assuming hyper-threading is supported
    num_threads_per_core = num_cores * hardware_threads_per_core

    puts "Number of threads per core: #{num_threads_per_core}"
end


get_number_of_cpus()
get_number_of_threads_per_core()