require 'serialport'
require 'slack-notifier'

MIN_TEMPERATURE = 500
MIN_MOISTURE = 500
MIN_LIGHT = 500
SLACK_WEBHOOK_URL = ''
SLACK_CHANNEL = ''
SLCAK_USERNAME = ''

ports = Dir.glob('/dev/cu.usbmodem*')
if ports.size != 1
  printf("did not found right /dev/cu.usbmodem* serial")
  exit(1)
end

s = SerialPort.new(ports[0], 9600, 8, 1, SerialPort::NONE)
#s = SerialPort.new('/dev/cu.usbmodem141111', 9600, 8, 1, SerialPort::NONE)

slack = Slack::Notifier.new WEBHOOK_URL do
  defaults channel: SLACK_CHANNEL,
           username: SLCAK_USERNAME
end

loop do
#  api.send(parse(s.readline(2)))
  stats = read_sensors(s)

  slack.ping('too cold') if stats[:temperature] < MIN_TEMPERATURE
  slack.ping('water') if stats[:moisture] < MIN_TEMPERATURE
  slack.ping('more light') if stats[:light] < MIN_TEMPERATURE

  sleep(0.5)
end

def read_sensor(serial)
  # s.readline(2)
  {
    temperature: 500,
    moisture: 500,
    light: 200
  }
end
