import { StyleSheet, Text, View } from 'react-native';

import * as AppleHealthKitExport from 'apple-healthkit-export';

export default function App() {
  return (
    <View style={styles.container}>
      <Text>{AppleHealthKitExport.hello()}</Text>
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#fff',
    alignItems: 'center',
    justifyContent: 'center',
  },
});
