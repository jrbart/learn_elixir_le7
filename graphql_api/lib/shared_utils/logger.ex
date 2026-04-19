defmodule SharedUtils.Logger do
  require Logger

  def debug(source, message), do: log(:debug, create_message(source, message))
  def info(source, message), do: log(:info, create_message(source, message))
  def warn(source, message), do: log(:warning, create_message(source, message))
  def error(source, message), do: log(:error, create_message(source, message))

  def error_with_stack(source, message) do
    log(:error, create_message(source, message))
    log(:error, Exception.format_stacktrace())
  end

  def create_message(source, message), do: "[#{source}] #{message}"

  def log(level, %{code: code, message: message, details: details}) do
    Logger.log(level, "#{code} - #{message} -- #{inspect(details)}")
  end

  def log(level, %{code: code, message: message}) do
    Logger.log(level, "#{code} - #{message}")
  end

  def log(level, message) do
    Logger.log(level, message)
  end
end
