defmodule ServoKnob do
  @moduledoc false
  use GenServer

  alias GrovePi.{RGBLCD, Analog, Potentiometer}

  defstruct [:potentiometer, :led]

  def start_link(pins) do
    GenServer.start_link(__MODULE__, pins)
  end

  def init([potentiometer, led]) do
    state = %ServoKnob{potentiometer: potentiometer, led: led}

    RGBLCD.start()
    RGBLCD.set_text("Ready!")
    Potentiometer.subscribe(potentiometer, :changed)
    {:ok, state}
  end

  def handle_info({_, :changed, %{value: value}}, state) do
    led_value = convert_to_pwm(value)
    led_text = format(led_value)

    # Write new value to led
    Analog.write(state.led, led_value)
    RGBLCD.set_text(led_text)

    {:noreply, state}
  end

  defp format(led_value) do
    "LED Value: #{Integer.to_string(led_value)}"
  end

  def handle_info(_message, state) do
    {:noreply, state}
  end

  defp convert_to_pwm(value) do
    # Convert adc_level value (0-1023) to pwm value (0-255)
    round(value / 5)
  end
end
