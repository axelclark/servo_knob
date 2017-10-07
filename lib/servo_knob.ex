defmodule ServoKnob do
  @moduledoc false
  use GenServer

  alias GrovePi.{RGBLCD, Analog, Potentiometer, PivotPi, Button}

  defstruct [:potentiometer, :led, :button, :button_value]

  def start_link(pins) do
    GenServer.start_link(__MODULE__, pins)
  end

  def init([potentiometer, led, button]) do
    state =
      %ServoKnob{
        potentiometer: potentiometer,
        led: led,
        button: button,
        button_value: 0
      }

    RGBLCD.start()
    PivotPi.start()
    RGBLCD.set_text("Ready!")
    Potentiometer.subscribe(potentiometer, :changed)
    Button.subscribe(button, :pressed)
    {:ok, state}
  end

  def handle_info({_, :changed, %{value: value}}, state) do
    led_value = convert_to_pwm(value)
    led_power = convert_to_power(led_value)
    led_text = format_led(led_power)
    Analog.write(state.led, led_value)
    RGBLCD.set_text(led_text)

    angle_value = convert_to_angle(value)
    servo_text = format_angle(angle_value)
    PivotPi.angle(1, angle_value)
    PivotPi.led(1, led_power)
    RGBLCD.set_cursor(1, 0)
    RGBLCD.write_text(servo_text)

    {:noreply, state}
  end

  def handle_info({_, :pressed, _}, %{button_value: value} = state) do
    new_value = next_value(value)
    button_led = button_led(new_value)
    PivotPi.angle(2, new_value)
    PivotPi.led(2, button_led)
    {:noreply, %{state | button_value: new_value}}
  end
  def handle_info(_message, state) do
    {:noreply, state}
  end

  defp convert_to_pwm(value) do
    # Convert adc_level value (0-1023) to pwm value (0-255)
    round((value / 1023) * 255)
  end

  defp convert_to_power(led_value) do
    round((led_value / 255) * 100)
  end

  defp format_led(power) do
    "LED Power: #{Integer.to_string(power)}"
  end

  defp convert_to_angle(value) do
    # Convert adc_level value (0-1023) to angle value (0-180)
    round((value / 1023) * 180)
  end

  defp format_angle(angle_value) do
    "Servo Angle: #{Integer.to_string(angle_value)}"
  end

  defp next_value(0), do: 180
  defp next_value(180), do: 0
  defp next_value(_), do: 0

  defp button_led(0), do: 0
  defp button_led(180), do: 100
  defp button_led(_), do: 0
end
