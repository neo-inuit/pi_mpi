#!/usr/bin/env ruby

# idea
#Put the LD LIBRARY in each shell env use the submission script for nef
#script dedicated for each server or keep everything on kali side?
#added opts gem to manage arguments
#added job_delayed gem to manage long background task

require 'net/ssh'

# variables
$error=0
$stream=""
$scheduler=0
$state=0
$hostname=""
$cmd=""
$g5k_geo="sophia"
$login="rmichela"
$output="pi_mpi_out.txt"
$nodes=1
$pbs_file="pi_mpi.pbs"
$prog_name="pi_mpi"
$arg=10000000
$jobid=0

#definitions
$scheduler_command = [[],[]]
# dirty $cmd for nef no jobid return
#["export LD_LIBRARY_PATH=/opt/openmpi/current/lib64 && mpirun.openmpi -np %{nodes} ./hello_mpi %{arg}"]

$scheduler_command = [["ssh #{$g5k_geo} mpirun.openmpi -mca btl ^openib -np %{nodes} --stdout %{output} %{prog} %{arg}", "ssh #{$g5k_geo} oarstat %{jobid}", "ssh #{$g5k_geo} oardel %{jobid}"], ["qsub -l nodes=%{nodes} -o %{output} %{pbs}", "qstat %{jobid}", "qdel %{jobid}"]]

#fonctions
def help
  puts "This script need 2 or 3 arguments"
  puts "First argument which scheduler : o for OAR and t for TORQUE"
  puts "Second argument what you want to do : run or stat or kill"
  puts "Third argument only if you choose run, the number of nodes"
end

def launch(hostname,login,cmd)
  begin
    puts("ssh connection #{hostname} #{login}")
    ssh = Net::SSH.start(hostname,login)

    # if oar choose
    if ($scheduler==0)
      puts("oar choose")
    #ssh2 = Net::SSH.start($g5k_geo,login)
    #ssh2 = ssh.exec!("ssh #{$g5k_geo}")
    #puts("oar choose #{ssh2}")
    #node reservation
    #oar = ssh2.exec!("oarsub -l /nodes=%{nodes}" % {nodes: $nodes})
    end
    puts("execution cmd #{cmd}")
    res = ssh.exec!(cmd)
    # read the output file if state = run
    if ($state==0)
    #res2 = ssh.exec!("cat #{$output}")
    end
    if ($scheduler==0)
    #ssh2.close
    end
    ssh.close
    puts res
    if ($state==0)
    $jobid = res
    #puts res
    end
  # rescue Exception => msg
  # # display the system generated error message
  # puts msg
  # puts "Unable to connect to #{hostname}"
  # PPP
  end
end

#main
if ARGV.empty? or ARGV.one? or ARGV.first.eql?("-h") or ARGV.first.eql?("--help")
  then puts "you need 2 arguments"
  help
else
  if ARGV.first.eql?("o")
    then puts "you choose OAR scheduler"
  $scheduler=0
  elsif ARGV.first.eql?("t")
    then puts "you choose TORQUE scheduler"
  $scheduler=1
  elsif ( ! $scheduler )
    $error=1
    $stream = "no good scheduler option"
  end
  if ARGV[1].eql?("run")
    then puts "you choose run operation"
    $state=0
    if ARGV[2].nil?() or !ARGV[2].to_i.is_a?(Integer) or (ARGV[2].to_i>20)
      then help
      exit
    else
      $nodes=ARGV[2]
      puts "you choose #{$nodes} nodes"
    end
  elsif ARGV[1].eql?("stat")
    
    
    then puts "you choose stat operation"
  $state=1
  elsif ARGV[1].eql?("kill")
    then puts "you choose kill operation"
  $state=2
  elsif ( ! $state )
    $error=2
    $stream = "no good state option"
  end

  if ($error>0) then puts stream
  elsif

  if ($scheduler==0)
  then $hostname = "g5k"
  $login="rmichelas"
  elsif ($scheduler==1)
  then $hostname = "nef-devel"
  $login="rmichela"
  end
    puts $hostname
    # added nodes number if needed (for run $cmd)
    $cmd = $scheduler_command[$scheduler][$state] % {nodes: $nodes, output: $output, pbs: $pbs_file, jobid: $jobid, prog: $prog_name, arg: $arg}
    # $cmd displayed
    puts $cmd
    launch($hostname,$login,$cmd)
  end
end