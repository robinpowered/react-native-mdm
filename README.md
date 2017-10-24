
# react-native-mdm

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

