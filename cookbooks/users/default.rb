require 'unix_crypt'

node[:users].each do |name|
  user "create user #{name}" do
    username name
    password UnixCrypt::SHA512.build(name)
    create_home true
    not_if "cat /etc/passwd | grep #{name}"
  end

  if ARGV.include?("docker") then
    execute "install sudo" do
      command <<-M
        apt-get update && apt-get install -y sudo && rm -rf /var/lib/apt/lists/*
      M
    end
  end

  execute "append sudo group #{name}" do
    command "usermod -G sudo #{name}"
  end

  execute "put authorized key" do
    user name
    cwd "/home/#{name}"
    command <<-M
    mkdir ~/.ssh
    curl -L https://github.com/#{name}.keys > ~/.ssh/authorized_keys
    chmod 700 ~/.ssh
    chmod 600 ~/.ssh/authorized_keys
    M
  end
end
