require 'etc'

def get_number_of_cpus
    puts "Number of CPU cores: #{Etc.nprocessors}"
end

