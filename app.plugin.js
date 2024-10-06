const { withInfoPlist } = require("@expo/config-plugins");

const withInfoPlistPlugin = (config, props) =>
  withInfoPlist(config, (config) => {
    if (props?.NSHealthShareUsageDescription !== false) {
      config.modResults.NSHealthShareUsageDescription =
        props.NSHealthShareUsageDescription ??
        `${config.name} wants to read your health data`;
    }

    if (props?.NSHealthUpdateUsageDescription !== false) {
      config.modResults.NSHealthUpdateUsageDescription =
        props.NSHealthUpdateUsageDescription ??
        `${config.name} wants to update your health data`;
    }

    return config;
  });

module.exports = withInfoPlistPlugin;
