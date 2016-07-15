module Sinatra
  module App
    module Routing
      module Tmp
        def self.registered(app)
          app.get '/api/v1/shelf-modules' do
            {
              data: [
                {
                  type: "shelf-modules",
                  id: "1",
                  attributes: {
                      name: "DCEngine",
                      key: "dc_engine",
                      pins: [
                        'shim', 'any', 'any'
                      ]
                  }
                },
                {
                  type: "shelf-modules",
                  id: "2",
                  attributes: {
                      name: "StepperMotor",
                      key: "stepper_motor",
                      pins: [
                        'any', 'any', 'any', 'any'
                      ]
                  }
                },
                {
                  type: "shelf-modules",
                  id: "3",
                  attributes: {
                      name: "Sensor",
                      key: "sensor",
                      pins: [
                        'analog'
                      ]
                  }
                },
                {
                  type: "shelf-modules",
                  id: "4",
                  attributes: {
                      name: "IRReciever",
                      key: "ir_rec",
                      pins: [
                        'shim'
                      ]
                  }
                },
                {
                  type: "shelf-modules",
                  id: "5",
                  attributes: {
                      name: "IRTransmiter",
                      key: "ir_trans",
                      pins: [
                        'shim'
                      ]
                  }
                },
                {
                  type: "shelf-modules",
                  id: "6",
                  attributes: {
                      name: "Sonar",
                      key: "sr_04",
                      pins: [
                        'any', 'any'
                      ]
                  }
                },
              ]
            }.to_json
          end
        end
      end
    end
  end
end
