require 'serialport'
require 'slack-notifier'

MIN_TEMPERATURE = ENV.fetch('MIN_TEMP', "18.0").to_f
MIN_MOISTURE = ENV.fetch('MIN_MOISTURE', "1000").to_i
MIN_LIGHT = ENV.fetch('MIN_LIGHT', "500").to_i
SLACK_WEBHOOK_URL = 'https://hooks.slack.com/services/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'
SLACK_CHANNEL = 'greenhouse'
SLACK_USERNAME = 'shelly'

port = ENV.fetch('PORT', 'cu.usbmodem*')
ports = Dir.glob("/dev/#{port}")
if ports.size != 1
  printf("did not found right /dev/#{port} serial")
  exit(1)
end

s = SerialPort.new(ports[0], 9600, 8, 1, SerialPort::NONE)

slack = Slack::Notifier.new SLACK_WEBHOOK_URL do
  defaults channel: SLACK_CHANNEL,
           username: SLACK_USERNAME
end

B = 4275
R0 = 100_000

def read_sensors(serial)
  output = {}
  command = serial.read(1)
  return output unless %w[t l m].include?(command)

  length = serial.read(1)
  val = serial.read(length.to_i).to_i

  if command == 't'
    r = 1023.0 / (val - 1.0)
    r = R0 * r
    celsius = 1.0 / (Math.log10(r / R0) / B + 1 / 298.15) - 273.15

    output[:temperature] = celsius
  elsif command == 'l'
    output[:light] = val
  elsif command == 'm'
    output[:moisture] = val
  end

  output
end

loop do
  stats = read_sensors(s)
  unless stats.empty?
    puts stats

    slack.ping("I'm feeling too cold") if stats.fetch(:temperature, MIN_TEMPERATURE + 1) < MIN_TEMPERATURE
    slack.ping("I need some water") if stats.fetch(:moisture, MIN_MOISTURE + 1) < MIN_MOISTURE
    slack.ping("I need more light") if stats.fetch(:light, MIN_LIGHT + 1) < MIN_LIGHT
  end

  sleep(0.1)
end
