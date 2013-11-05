#!/usr/bin/env ruby

# idea
#Put the LD LIBRARY in each shell env use the submission script for nef
#script dedicated for each server or keep everything on kali side?

require 'net/ssh'

# variables
error=0
stram=""
hostname=""
cmd=""
login="rmichela"
$cores=1

#definitions
scheduler_command = [[],[]]
scheduler_command = [["oarrun", "oarstat", "oarkill"], ["export LD_LIBRARY_PATH=/opt/openmpi/current/lib64 && mpirun.openmpi -np %{cores} ./hello_mpi %{arg}", "qstat | grep #{login}", "qkill"]]

#fonctions
def help
  puts "This script need 2 or 3 arguments"
  puts "First argument which scheduler : o for OAR and t for TORQUE"
  puts "Second argument what you want to do : run or stat or kill"
  puts "Third argument only if you choose run, the number of cores"
end

def launch(hostname,login,cmd)
  begin
    ssh = Net::SSH.start(hostname,login)
    res = ssh.exec!(cmd)
    ssh.close
    puts res
  rescue
    puts "Unable to connect to #{hostname}"
  end
end

#main
if ARGV.empty? or ARGV.one? or ARGV.first.eql?("-h") or ARGV.first.eql?("--help")
  then puts "you need 2 arguments"
  help
else
  if ARGV.first.eql?("o")
    then puts "you choose OAR scheduler"
  scheduler=0
  elsif ARGV.first.eql?("t")
    then puts "you choose TORQUE scheduler"
  scheduler=1
  elsif ( ! scheduler )
    error=1
    stream = "no good scheduler option"
  end
  if ARGV[1].eql?("run")
    then puts "you choose run operation"
  state=0
    if ARGV[2].nil?() or !ARGV[2].to_i.is_a?(Integer) or (ARGV[2].to_i>20)
      then help
      exit
    else
      $cores=ARGV[2]
      puts "you choose #{$cores} cores"      
    end    
  elsif ARGV[1].eql?("stat")
    then puts "you choose stat operation"
  state=1
  elsif ARGV[1].eql?("kill")
    then puts "you choose kill operation"
  state=2
  elsif ( ! state )
    error=2
    stream = "no good state option"
  end

  if (error>0) then puts stream
  elsif

  if (scheduler==0)
  then hostname = "g5k"
  elsif (scheduler==1)
  then hostname = "nef-devel"
  end
    puts hostname
    # agregation du nb de coeur si besoin
    cmd = scheduler_command[scheduler][state] % {cores: $cores, arg: "world"}
    # cmd displayed
    puts cmd
    launch(hostname,login,cmd)
  end
end