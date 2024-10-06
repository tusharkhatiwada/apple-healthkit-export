import * as React from 'react';

import { AppleHealthKitExportViewProps } from './AppleHealthKitExport.types';

export default function AppleHealthKitExportView(props: AppleHealthKitExportViewProps) {
  return (
    <div>
      <span>{props.name}</span>
    </div>
  );
}
