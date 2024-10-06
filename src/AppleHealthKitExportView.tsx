import { requireNativeViewManager } from 'expo-modules-core';
import * as React from 'react';

import { AppleHealthKitExportViewProps } from './AppleHealthKitExport.types';

const NativeView: React.ComponentType<AppleHealthKitExportViewProps> =
  requireNativeViewManager('AppleHealthKitExport');

export default function AppleHealthKitExportView(props: AppleHealthKitExportViewProps) {
  return <NativeView {...props} />;
}
