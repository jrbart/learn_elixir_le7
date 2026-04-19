defmodule SharedUtils.Error do
  def not_found(message, %{details: details}) do
    create_error(:not_found, message, details)
  end

  def internal_server_error(message, %{details: details}) do
    create_error(:internal_server_error, message, details)
  end

  def not_acceptable(message, %{details: details}) do
    create_error(:not_acceptable, message, details)
  end

  def conflict(message, %{details: details}) do
    create_error(:conflict, message, details)
  end

  def create_error(code, message, details) do
    %{message: message, code: code, details: details}
  end
end
