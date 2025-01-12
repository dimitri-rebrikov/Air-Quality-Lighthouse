# Air-Quality-Lighthouse
ESPhome based indoor air quality monitor built inside of a lighthouse model.

It is based on the genious idea of https://www.thingiverse.com/thing:5652921 where the ESP module's heat create a chimney effect inside of the lighthouse model ensuring the air quality sensor always gets the air from outside of the housing.

I will provide the same functionality (the direct led status light and the detailed info sent to the home automation server) but instead of coding in C/C++ i want ot use the ESPhome environment to wire all the parts together.

The design of the lighthouse shall make it possible to use different ESP modules.

under construction...

- [Open SCAD design of the Lighthouse](./Lighthouse.scad)
- [ESPHome definition of the Air Quality notification](./esphome.yaml)

howto run esphome: `esphome -s esphome_name <your-name-for-the-device> run .\esphome.yaml`
