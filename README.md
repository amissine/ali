# ali
The Arbitrage Logistics International (ALI) project

## Contents

 - [Setup](#setup)
 - [ALI Roadmap](#ali-roadmap)
 - [Simulating Trades with SMES](#simulating-trades-with-smes)
 - [Understanding Bitstamp orders and trades](#understanding-bitstamp-orders-and-trades)

 ## Setup

 The following steps have been tested on Ubuntu 16.04 LTS and MacOS 12.3 operating systems.

 1. Allow _sudoers_ to `sudo` without having to type the password. On MacOS, we assume that you are a member of the _admin_ group and, therefore, a _sudoer_. If this is the case, then, using `sudo visudo`, add/update the following lines:
 ```
##
## User privilege specification
##
root ALL=(ALL) ALL 
%admin  ALL=(ALL) NOPASSWD: ALL 
```
On Linux, add the following line
```
alec  ALL = NOPASSWD: ALL
```
with `sudo vi /etc/sudoers.d/ctl_admins`, having replaced `alec` with your own `username`. Then run `sudo chmod 0440 /etc/sudoers.d/ctl_admins`.

 2. If you want the box to be a public server, you need the SSH server up and running on the box. On a MacOS box, try [this](http://osxdaily.com/2011/09/30/remote-login-ssh-server-mac-os-x/). Otherwise, run
```
sudo apt install openssh-server
```

 3. Install `vim`, `git`, `curl`, `node` and `npm` with native dev support. On a Linux box, run
```
sudo add-apt-repository ppa:jonathonf/vim
sudo apt update
sudo apt install vim git curl
curl -sL https://deb.nodesource.com/setup_8.x | sudo -E bash -
sudo apt-get install -y nodejs
sudo apt-get install gcc g++ make
sudo npm i -g npm
```

 4. Clone the ALI project from github, install the dependencies. Run
```
git clone https://github.com/amissine/ali.git
cd ./ali
npm install
```

 ## ALI Roadmap

 The goal of the project is to establish infrastructure and to provide tools for automated exchange of crypto tokens using the APIs of the publicly available exchanges. The infrastructure supports individual devices behind routers and does not require any special router configuration. The tools support both paper trading and the real thing. The whole project is open source.

 The ALI roadmap steps are as follows:

 1. Using public trades and orders from Bitfinex and Bitstamp, build and maintain the order book for each exchange. Add more exchanges to the picture.

 2. Using the collection of the order books, make it possible to determine and place private order(s) to any of the available exchanges.

 3. Support paper trading by simulating trades with SMES (see below).

 4. Support individual devices behind routers.

 5. Support private trading strategies in the form of pluggable trading bots.

 ## Simulating Trades with SMES

 When a trade occurs, some real market maker's order (RMMO) gets executed fully
or partially. If we shade the RMMO with our simulated order (SO), we can claim
this trade to be ours. To shade an RMMO with an SO, the SO must be entered
into our book before the RMMO. This way we can pretend we are the valid market
maker for our simulation purposes.

So, when an SO enters our book (0), it has no RMMO to shade. And it will never
get executed until it (1) shades some RMMO that (2) eventually gets executed.
Before (2) happens, the RMMO could get canceled - and this would bring our SO
back to (0). After (2) happens, we claim a full or partial execution of our SO.
The SO will remain in our book until it either gets executed fully or we cancel
it. As long as it is there, it will need an RMMO to shade.

Below is some real data from Bitfinex. Let us take a look at it and see how we
could inject an SO into it to claim selling 0.002672 BTC for 7519.5 USD (line
57).
```
[ 12635279607, 7519.5, -0.06671987 ]               #47
[ 12635280369, 7519.5, -0.5 ]                      #48
[ 12635280544, 7519.5, -1.25 ]
[ 12635281758, 7519.5, -1.25 ]

[ 12635279607, 0, -1 ]                             #52

[ 12635282843, 7519.5, -1.50000001 ]
[ 12635282970, 7519.5, -1.33986746 ]

[ [ 250266516, 1527351561486, 0.002672, 7519.5 ] ] #57

[ 12635280369, 7519.5, -0.497328 ]                 #59
```
The earliest order here has ID 12635279607 (line 47), but eventually it gets
canceled (line 52) and order ID 12635280369 gets partially executed (line 57)
and updated in the book (line 59). Now, if we injected our SO
(for example, -2.0 @ 7519.5) between lines 47 and 48, we could claim its
partial execution. And, if the execution amount on line 57 was not 0.002672,
but more than 0.5, order ID 12635280369 would have been executed fully and
our SO would end up shading order ID 12635280544.

I am quite sure I will have tons of fun implementing such a simple thing like
this Simple Message Exchange Simulator (SMES). See also:
[https://www.youtube.com/watch?v=6POcQ5wiUa4](https://www.youtube.com/watch?v=6POcQ5wiUa4)

## Understanding Bitstamp orders and trades
```
[1769146509,6325.67,-0.00365539,1530388085833214] #75
[1769062503,6325.67,8.02591708, 1530388085866792] #76
[[69383082,1530388085000,-0.00365539,6325.67]]    #77

[1769146590,6325.67,-0.02357692,1530388087675591] #79
[1769062503,6325.67,8.00234016,1530388087704630]  #80  8.02591708-0.02357692=8.00234016
[[69383085,1530388087000,-0.02357692,6325.67]]

[1769062503,6325.67,8.00113552,1530388103153949]  #83  8.00234016-0.00120464=8.00113552
[[69383093,1530388103000,-0.00120464,6325.67]]

[1769149714,6325.67,-0.5,1530388165369216]        #86
[1769149714,0,0,         1530388165434923]        #87
```
The taker's order may (lines 75-77, 79-80) or may not (line 83) be present.

When an order is canceled right after is has been created (lines 86, 87),
it may not get executed.

And here's an example of Bitstamp order lifecycle:
```
order_created order={ order_type: 0,
  bitstamp   price: 6344.08,
  bitstamp   datetime: '1530377931',
  bitstamp   amount: 0.08643278,
  bitstamp   id: 1768619888,
  bitstamp   microtimestamp: '1530377931251784' }

order_changed order={ order_type: 0,
  bitstamp   price: 6344.08,
  bitstamp   datetime: '1530377931',
  bitstamp   amount: 0.08389202,
  bitstamp   id: 1768619888,
  bitstamp   microtimestamp: '1530377934033720' }

recv msg: [-1,"te",[69378557,1530377934000,-0.00254076,6344.08]]

order_deleted order={ order_type: 0,
  bitstamp   price: 6344.08,
  bitstamp   datetime: '1530377931',
  bitstamp   amount: 0.08389202,
  bitstamp   id: 1768619888,
  bitstamp   microtimestamp: '1530377943133631' }

0.08643278-0.00254076=0.08389202
```
Order converted to bitfinex format:
```
[ 1768619888, 6344.08, 0.08643278 ]
[ 1768619888, 6344.08, 0.08389202 ]
[ 1768619888, 0, 1 ]
```
