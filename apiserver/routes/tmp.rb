module Sinatra
  module App
    module Routing
      module Tmp
        def self.registered(app)
          app.get '/api/v1/device-builds' do
            {
              data: [
                {
                  type: "device-build",
                  id: "917a19b19c27fe0001cs9cfe",
                  attributes: {
                    name: "BUG",
                    'modues-ids': [],
                  }
                },
              ]
            }.to_json
          end

          app.get '/api/v1/shelf-modules' do
            {
              data: [
                {
                  type: "shelf-modules",
                  id: "917a19b19c27fe0001c09cfe",
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
                  id: "927a19b19c27fe0001c09cfe",
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
                  id: "937a19b19c27fe0001c09cfe",
                  attributes: {
                      name: "Sensors",
                      key: "sensors",
                      pins: [
                        'analog', 'analog', 'analog', 'analog', 'analog'
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
