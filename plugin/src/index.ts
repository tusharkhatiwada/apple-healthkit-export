import { ConfigPlugin, withInfoPlist } from "expo/config-plugins";

const withAppleHealthKitExport: ConfigPlugin<{
  NSHealthShareUsageDescription: string;
  NSHealthUpdateUsageDescription: string;
}> = (config, props) => {
  config = withInfoPlist(config, (config) => {
    config.modResults.NSHealthShareUsageDescription = props.NSHealthShareUsageDescription;
    config.modResults.NSHealthUpdateUsageDescription =
      props.NSHealthUpdateUsageDescription;
    return config;
  });
  return config;
};

export default withAppleHealthKitExport;
