# University of Michigan Hardened Ubuntu Configuration

## About
This repository contains necessary configurations to create a secured Ubuntu image for use as a server or a workstation.

## How to use
1. Get the Ubuntu 16.04 CIS STIG role from https://github.com/florianutz/Ubuntu1604-CIS
  * Alternatively, you can create a `requirements.yml` file containing:
  ```
  - src: https://github.com/florianutz/Ubuntu1604-CIS.git
  ```
  Then run `ansible-galaxy install -p roles -r requirements.yml`

## To-Do List
* Create preseed file
