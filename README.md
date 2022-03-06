# AHB-Lite-Slave-VIP

## TestBench Architecture:

![image](https://user-images.githubusercontent.com/71690787/156921559-75416eec-b76a-4bb9-a7d6-ad0e8460191f.png)

## TestBench Components
* Transaction Class
* Generator Class
* Interface
* Driver Class
* Monitor
* Scoreboard
* Environment
* Test
* TestBench Top

## Supported Simulators & Tools
- [x] Aldec Riviera Pro 2020.04
- [x] Cadence Xcelium 20.09
- [x] Mentor Questa 2021.3
- [x] Synopsys VCS 2020.03

## Supported Tests
- [x] Single Burst
- [x] Increment Burst of Undefined Length
- [x] INCR & WRAP Tests (4,8,16 Beats)

## How to run tests

1. Change contraints in the `transaction.sv` file according to the test you want to run.
2. Comment/uncomment the tests to be run in the `environment.sv` file.
3. You can change the number of transactions to be run from the `random_test.sv` file by changing `repeat_count` value.

