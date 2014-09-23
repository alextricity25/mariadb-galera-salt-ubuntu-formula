#This salt state file will install and configure haproxy


haproxy:
  pkg.installed:
    - name: haproxy
