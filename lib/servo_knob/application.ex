defmodule ServoKnob.Application do
  @moduledoc false
  use Application

  @potentiometer_pin 16 # Port A2
  @led_pin 3 # Port D3
  @button_pin 14 #Port A0

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      # Start the GrovePi sensor that we want
      worker(GrovePi.Potentiometer, [@potentiometer_pin]),
      worker(GrovePi.Button, [@button_pin]),

      # Start the main app
      worker(ServoKnob, [[@potentiometer_pin, @led_pin, @button_pin]]),
    ]

    opts = [strategy: :one_for_one, name: ServoKnob.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
