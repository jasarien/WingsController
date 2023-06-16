import uasyncio as asyncio
import network
import time
import random
import logging
from inventor import Inventor2040W, SERVO_1, SERVO_2
import tinyweb

AUTO = 0
MANUAL = 1
STEADY = 2

mode = STEADY

board = Inventor2040W()
servo1 = board.servos[SERVO_1]
servo2 = board.servos[SERVO_2]
wing_position_percent = 100

SERVO_MIN = int(servo1.min_value())
SERVO_MAX = int(servo1.mid_value()) + 5

ssid = 'Wings'
password = 'abcd1234'

wlan = network.WLAN(network.AP_IF)
wlan.config(essid=ssid, password=password)
wlan.active(True)

while wlan.active == False:
    pass

print("Access point active")
print(wlan.ifconfig())

server = tinyweb.webserver()

@server.route('/wings/auto')
async def index(request, response):
    await response.start_html()
    await response.send('auto')
    global mode
    mode = AUTO
    
@server.route('/wings/steady')
async def index(request, response):
    await response.start_html()
    await response.send('steady')
    global mode
    mode = STEADY
    
@server.route('/wings/manual')
async def index(request, response):
    print(request.query_string)
    await response.start_html()
    await response.send('manual')
    global mode, wing_position_percent
    mode = MANUAL
    wing_position_percent = int(request.query_string)

for s in board.servos:
    s.enable()

async def flap():
    num_flaps = random.randint(1, 4)
    should_wait = True
    
    global mode 
    
    for flap in range(num_flaps):
        if mode != AUTO:
            should_wait = False
            break
        
        steps = random.randint(2, 8)
        for angle in range(SERVO_MAX, SERVO_MIN, -steps):
            if mode != AUTO:
                should_wait = False
                break
            servo1.value(angle)
            servo2.value(-angle)
            await asyncio.sleep(0.02)

        steps = random.randint(2, 8)
        for angle in range(SERVO_MIN, SERVO_MAX, steps):
            if mode != AUTO:
                should_wait = False
                break
            servo1.value(angle)
            servo2.value(-angle)
            await asyncio.sleep(0.02)
    if should_wait:
        waitTime = random.randint(1, 3)
        await asyncio.sleep(waitTime)

async def set_position():
    servo1.to_percent(wing_position_percent, 0, 100, servo1.min_value(), servo1.mid_value() + 5)
    servo2.to_percent(100 - wing_position_percent, 0, 100, servo2.mid_value() - 5, servo2.max_value())

async def steady():
    for i in range(0, 100):
        servo1.to_percent(i, 0, 100, servo1.min_value(), servo1.mid_value() + 5)
        servo2.to_percent(100 - i, 0, 100, servo2.mid_value() - 5, servo2.max_value())
        await asyncio.sleep(0.01)
    for i in range(0, 100):
        servo1.to_percent(100 - i, 0, 100, servo1.min_value(), servo1.mid_value() + 5)
        servo2.to_percent(i, 0, 100, servo2.mid_value() - 5, servo2.max_value())
        await asyncio.sleep(0.01)

async def start_server():
    await server.run(host="0.0.0.0", port=80)

async def run_wings():
    while True:
        if mode == AUTO:
            await flap()
        elif mode == STEADY:
            await steady()
        else:
            await set_position()
        await asyncio.sleep(0.1)

async def main():
    asyncio.create_task(run_wings())
    asyncio.create_task(start_server())
    await asyncio.sleep(99999)
    
asyncio.run(main())