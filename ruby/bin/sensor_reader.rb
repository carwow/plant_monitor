require 'serialport'
require 'slack-notifier'

MIN_TEMPERATURE = 550
MIN_MOISTURE = 1000
MIN_LIGHT = 500
SLACK_WEBHOOK_URL = 'https://hooks.slack.com/services/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'
SLACK_CHANNEL = 'greenhouse'
SLACK_USERNAME = 'shelly'

ports = Dir.glob('/dev/cu.usbmodem*')
if ports.size != 1
  printf("did not found right /dev/cu.usbmodem* serial")
  exit(1)
end

s = SerialPort.new(ports[0], 9600, 8, 1, SerialPort::NONE)

slack = Slack::Notifier.new SLACK_WEBHOOK_URL do
  defaults channel: SLACK_CHANNEL,
           username: SLACK_USERNAME
end

def read_sensors(serial)
  output = {}
  command = serial.read(1)
  return output unless %w[t l m].include?(command)

  length = serial.read(1)
  val = serial.read(length.to_i).to_i

  if command == 't'
    output[:temperature] = val
  elsif command == 'l'
    output[:light] = val
  elsif command == 'm'
    output[:moisture] = val
  end

  output
end

loop do
  stats = read_sensors(s)

  slack.ping('too cold') if stats.fetch(:temperature, MIN_TEMPERATURE + 1) < MIN_TEMPERATURE
  slack.ping('more water') if stats.fetch(:moisture, MIN_MOISTURE + 1) < MIN_MOISTURE
  slack.ping('too dark') if stats.fetch(:light, MIN_LIGHT + 1) < MIN_LIGHT

  sleep(0.1)
end

