import AppleHealthKitExportModule from "./AppleHealthKitExportModule";

export function requestAuthorization(identifiers: string[]) {
  return AppleHealthKitExportModule.requestAuthorization(identifiers);
}

export function exportHealthData(params: {
  identifiers: string[];
  startDate: Date;
  endDate: Date;
}) {
  return AppleHealthKitExportModule.exportHealthData(params);
}
