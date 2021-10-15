import React, {Component} from 'react';
import AsyncStorage from '@react-native-async-storage/async-storage';
import RNFS from 'react-native-fs';
import {
    Button,
  StyleSheet,
  View,
  Text,
  TextInput,
} from 'react-native';


const rootPath = RNFS.DocumentDirectoryPath;

export default class Home extends Component
{
  
    state={
        firstName:'',
        lastName:'',
        nickName:'',
        age: '',
        lastScore: '-1',
    };
    constructor(props){
        super(props);
        this.getUserDetails();
    }

    
    componentDidMount=()=> {
      this._unsubscribe = this.props.navigation.addListener('focus', () => {
       console.log('focus')
       setTimeout( async () =>{                                             //Reading score from file
        try {
          const path =rootPath+ "/score.txt";
          const contents = await RNFS.readFile(path, "utf8")                  
          if(contents !== null) {
            this.setState({lastScore: contents})
          }
        } catch (e) {
        }  
      }, 1000);
      });
    }
  
    componentWillUnmount() {
      this._unsubscribe();
    }

    getUserDetails = async () => {
        try {
          const firstName = await AsyncStorage.getItem('firstName')
          const lastName = await AsyncStorage.getItem('lastName')
          const nickName = await AsyncStorage.getItem('nickName')
          const age = await AsyncStorage.getItem('age')
          if(firstName !== null) {
            this.setState({firstName: firstName})
          }
          if(lastName !== null) {
            this.setState({lastName: lastName})
          }
          if(nickName !== null) {
            this.setState({nickName: nickName})
          }
          if(age !== null) {
            this.setState({age: age})
          }
        } catch(e) {
          // error reading value
        }
      }
    
    storeUserDetails = async () => {
        try {
          await AsyncStorage.setItem('firstName', this.state.firstName)
          await AsyncStorage.setItem('lastName', this.state.lastName)
          await AsyncStorage.setItem('nickName', this.state.nickName)
          await AsyncStorage.setItem('age', this.state.age)
          
          alert("Data Saved Successfully");
        } catch (e) {
          console.log('Could not save');
        }
      }

  render(){
    var userMessage;
    var scoreMessage;
    if(this.state.lastScore!=='-1'){
      scoreMessage= <Text style={{fontSize: 18}}>Last Score: {this.state.lastScore}</Text>}
    if(this.state.firstName!==''){
      userMessage=
        <Text style={{fontSize: 18}}>User: {this.state.firstName} {this.state.lastName} '{this.state.nickName}' ({this.state.age} years old)</Text>}
      
    return (
      <View  style={styles.container}>
        <Text style={styles.headingStyle}>Welcome to Quiz Master</Text>
        <Text> (Your skills will be tested here!)</Text>
        <Text></Text>
        <Text style={styles.headingStyle}>Personal Details</Text>
        <Text>First Name</Text>
        <TextInput 
            placeholder='Enter first name'
            keyboardType= 'default'
            underlineColorAndroid= '#000000'
            onChangeText={firstName=> this.setState({firstName})}
            value={this.state.firstName}
        />

        <Text>Last Name</Text>
        <TextInput 
            placeholder='Enter last name'
            keyboardType= 'default'
            underlineColorAndroid= '#000000'
            onChangeText={lastName=> this.setState({lastName})}
            value={this.state.lastName}
        />
        
        <Text>Nick Name</Text>
        <TextInput 
            placeholder='Enter nick name'
            keyboardType= 'default'
            underlineColorAndroid= '#000000'
            onChangeText={nickName=> this.setState({nickName})}
            value={this.state.nickName}
        />
        
        <Text>Age</Text>
        <TextInput 
            placeholder='Enter age'
            keyboardType= 'numeric'
            underlineColorAndroid= '#000000'
            onChangeText={age=> this.setState({age})}
            value={this.state.age}
        />

      <View style={{flexDirection:"row" ,padding: 15, justifyContent: 'space-between',width: "90%", }}>
        <Text></Text>
        <Button title="Quiz" onPress={()=>{this.props.navigation.navigate('Quiz')}}/>
        
        <Text></Text>
        <Button title="Done"  onPress={this.storeUserDetails}/>
        <Text></Text>
      </View>
      <Text></Text>
      {userMessage}    
      <Text></Text>
      {scoreMessage}
      </View>
    );
  }
}

const styles= StyleSheet.create({
  container: {
    flex: 1,
    justifyContent: 'center',
    backgroundColor: '#7fffd4',
    padding: 20
  },
  headingStyle: {
    fontSize: 27
  }
})
