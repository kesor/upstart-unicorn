## Ubuntu Upstart & Ruby Unicorn

##### WARNING: Do not use in production! This is a proof of concept only.

###### Introduction

Ubuntu `upstart` is an event-based replacement for the `init` daemon, it handles starting and supervising Linux services. While originally developed for Ubuntu, it can be used on any other Linux distribution.

Ruby `unicorn` is a popular HTTP server for Rack applications that has its own system of process management.

Unfortunately `upstart` is incompatible with `unicorn`'s master "phoenix" way of respawning to a new process upon receiving the `SIGUSR2` signal.

---

This little demo is a proof of concept utilizing `upstart`'s little known utility called `upstart-socket-bridge`. The U-S-B is similar to how `xinetd` works, it listens to a socket and allows a process to take over the file descriptor once a connection has been made. U-S-B is passing the file descriptor information via the environment variable `UPSTART_FDS`.

Ruby `unicorn` has its own little known feature, one that is actually used to respawn into a new master. Unicorn is passing the previous file descriptors to a new master process via the `UPSTART_FD` environment variable.

The idea in this project, especially the ``unicorn_wrapper.rb`` file, is forgoing the Unicorn launch of its first master, and allowing Upstart to become that master via U-S-B unix sockets.

While this is an interesting experiment, there are a lot of bugs involved and this process is not recommended for actual production use. YMMV.

---

To test this demo, you will need an Ubuntu system (tested on Ubuntu 12.04 Precise), and a Rails project configured to be served via unicorn using the `unicorn_wrapper.rb` file.

Setup:

  - place `unicorn_wrapper.rb` in your rails project
  - edit project location and place `unicorn_upstart.conf` as `/etc/init/unicorn.conf`
  - copy nginx configuration `unicorn_nginx.conf` to `/etc/nginx/sites-enabled/default`
  - restart nginx
  
Troubleshooting:

  - upstart log file shows as `/var/log/uptart/unicorn.log` and has useful information
  - install `socat` with `sudo apt-get install socat` and test connectivity using `sudo socat stdin unix-client:/var/run/unicorn.sock`
  - nginx is using `www-data` as its user by default, configured in `/etc/nginx/nginx.conf` which might not have permissions writing to the unicorn socket owned by root. change nginx user to root helps resolve this.
