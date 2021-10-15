import * as React from 'react';
import { NavigationContainer } from '@react-navigation/native';
import { createStackNavigator } from '@react-navigation/stack';
import Home from './routes/Home';
import Quiz from './routes/Quiz';

const Stack = createStackNavigator();

function App() {
  return (
    <NavigationContainer>
      <Stack.Navigator initialRouteName="Home">
      <Stack.Screen name="Home" component={Home} options={{ title: "Quiz Master",headerStyle: {  backgroundColor: '#008080'},}} />
      <Stack.Screen name="Quiz" component={Quiz} options={{headerLeft:null, headerStyle: { backgroundColor: '#008080'  }}}/>
      </Stack.Navigator>
    </NavigationContainer>
  );
}

export default App;