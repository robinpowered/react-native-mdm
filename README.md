
# Install react-native-mdm
```
npm install react-native-mdm
```

# Setup

```javascript
import MobileDeviceManager from 'react-native-mdm';
```

```javascript
MobileDeviceManager
  .isSupported()
  .then(supported => console.log(supported))
  .catch(error => console.log(error));
```

```javascript
MobileDeviceManager
  .getConfiguration()
  .then(result => console.log(result))
  .catch(error => console.log(error));
```

```javascript
componentDidMount() {
  this.MDMListener = MobileDeviceManager.addListener(this.MDMDidUpdate);
}

MDMDidUpdate(data) {
  console.log('AppConfig data was changed');
  console.log(data);
}

componentWillUnmount() {
    this.MDMListener.remove();
}
```

## Additional steps for Android

Schema and extra settings needed for `AndroidManifest.xml` to obtain app configurations from MDM provider. [Android documentation regarding this](https://developer.android.com/work/managed-configurations.html)

```xml
<meta-data android:name="android.content.APP_RESTRICTIONS"
  android:resource="@xml/app_restrictions" />
```

```xml
<?xml version="1.0" encoding="utf-8"?>
<restrictions xmlns:android="http://schemas.android.com/apk/res/android">

  <restriction
    android:key="downloadOnCellular"
    android:title="@string/download_on_cell_title"
    android:restrictionType="bool"
    android:description="@string/download_on_cell_description"
    android:defaultValue="true" />

</restrictions>
```
