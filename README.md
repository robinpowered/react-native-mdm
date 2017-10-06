
# react-native-mdm

```javascript
import MDMManager from 'react-native-mdm';
```

```javascript
MDMManager
  .isSupported()
  .then(supported => console.log(supported))
  .catch(error => console.log(error));
```

```javascript
MDMManager
  .getConfiguration()
  .then(result => console.log(result))
  .catch(error => console.log(error));
```

```javascript
componentDidMount() {
  this.MDMListener = MDMManager.addListener(this.MDMDidUpdate);
}

MDMDidUpdate(data) {
  console.log('AppConfig data was changed');
  console.log(data);
}

componentWillUnmount() {
    this.MDMListener.remove();
}
```

