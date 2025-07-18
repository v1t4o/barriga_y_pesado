class PaymentsController < ApplicationController
  def index
    render json: {}, status: :ok
  end

  def create
    render json: {}, status: :created
  end
end