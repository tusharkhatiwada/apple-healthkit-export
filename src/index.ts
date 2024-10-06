import { NativeModulesProxy, EventEmitter, Subscription } from 'expo-modules-core';

// Import the native module. On web, it will be resolved to AppleHealthKitExport.web.ts
// and on native platforms to AppleHealthKitExport.ts
import AppleHealthKitExportModule from './AppleHealthKitExportModule';
import AppleHealthKitExportView from './AppleHealthKitExportView';
import { ChangeEventPayload, AppleHealthKitExportViewProps } from './AppleHealthKitExport.types';

// Get the native constant value.
export const PI = AppleHealthKitExportModule.PI;

export function hello(): string {
  return AppleHealthKitExportModule.hello();
}

export async function setValueAsync(value: string) {
  return await AppleHealthKitExportModule.setValueAsync(value);
}

const emitter = new EventEmitter(AppleHealthKitExportModule ?? NativeModulesProxy.AppleHealthKitExport);

export function addChangeListener(listener: (event: ChangeEventPayload) => void): Subscription {
  return emitter.addListener<ChangeEventPayload>('onChange', listener);
}

export { AppleHealthKitExportView, AppleHealthKitExportViewProps, ChangeEventPayload };
