import React, {Component, createRef} from 'react';
import Home from '../routes/Home';
import data from '../json/questions.json';
import update from 'immutability-helper';
import RNFS from 'react-native-fs';
import RadioForm, {RadioButton, RadioButtonInput, RadioButtonLabel} from 'react-native-simple-radio-button';
import {
  Button,
  StyleSheet,
  View,
  Text,
  ActivityIndicator,
  FlatList,  
  BackHandler,
} from 'react-native';

const rootPath = RNFS.DocumentDirectoryPath;

export default class Quiz extends Component
{
 
flatList=createRef();
  
    constructor(props){
        super(props);

        this.state = {
            isLoading: true, // check if json data is fetching
            dataSource: [], // store questions
            totalQuestions: 0,
            currentAnswer:'',
            userAnswers: [],
            correctAnswers:[],
            flagForNextButton: false,
        };
    }

    componentDidMount(){
        this.setState({
            isLoading: false,
            dataSource: data.Questions,
            totalQuestions: data.Questions.length,
        });
        BackHandler.addEventListener('hardwareBackPress', this.backAction);
    }

    componentWillUnmount(){
      BackHandler.removeEventListener('hardwareBackPress', this.backAction);
    }

    backAction=()=>{
      alert('Can\'t go back at this stage.\nPlease complete the quiz!')
      return true;
    }

    updateAnswers(index,currentAns) {
      this.setState((state) => {
      return update(state, {
          userAnswers: {
            [index]: {
              $set: this.state.currentAnswer
            }
           },
           correctAnswers:{
            [index]: {
              $set: currentAns
            },
          }
        })
      }, () => {this.setState({flagForNextButton:false})                 // Hiding next button
      if(index===this.state.totalQuestions-1){              //If last question is answered, go to checkAndSaveScore
        this.checkAndSaveScore()  
      }});
    }


    checkAndSaveScore() {
      let score = 0;
      for(let i = 0; i < this.state.totalQuestions; i++){
        if(this.state.userAnswers[i]===this.state.correctAnswers[i]){
          score=score+1
        }
      }
      score=(score/this.state.totalQuestions) *100                            // Score calculated
      const path=rootPath+ "/score.txt";
      RNFS.writeFile(path, String(score)+'%   ', 'utf8')                      //Writing to file
      .then((success) => {
          console.log('Score written into file!');
        })
      .catch((err) => {
          console.log(err.message);});
    }


  render(){
      // show loading screen when json data is fetching
      if(this.state.isLoading){
        return(
            <View style={{flex:1, padding: 20}}>
                <ActivityIndicator />
            </View>
        );
      }
    return (
      <View  style={styles.container}>       
        <FlatList 
        snapToInterval={370}
        decelerationRate={0}
        ref={this.flatList}
        horizontal
        data={this.state.dataSource}
          renderItem={({item,index}) => {
            var options = [
              {label: item.optionA, value: item.optionA },
              {label: item.optionB , value: item.optionB },
              {label: item.optionC, value: item.optionC },
              {label: item.optionD , value: item.optionD },
            ];
           return (
              <View style={styles.info}>
                <View>
                    <Text style={styles.questionHeading}>Question</Text>
                </View>
                <Text style={styles.textStyle}>{item.question}</Text> 
                <Text style={styles.optionHeading}>Options</Text>
                <View style={{padding: 15, paddingTop:10}}>
                <RadioForm
                  radio_props={options}
                  initial={-1}
                  onPress={(label)=>{
                    this.setState({currentAnswer: label, flagForNextButton: true})  
                  }}
                  selectedButtonColor={'green'}
                  selectedLabelColor={'green'}
                  labelStyle={{fontSize:23, padding:10}}
                  animation={false}
                />
                <Text></Text> 
                {
                  this.state.flagForNextButton===true?
                  <Button   title={(index<this.state.totalQuestions-1)?"Next":"End"}
                              onPress={()=>{
                                this.updateAnswers(index, item.ans)
                              if(index<this.state.totalQuestions-1){              //Check for last question
                                this.flatList.current.scrollToIndex({
                                  index: index+1,
                                  animated: true});}
                              else{
                                this.props.navigation.navigate(Home)              //Last question answered
                              }
                            }
                          }
                  />:null
                } 
                </View>
              </View>
            )
          }}
          keyExtractor={(item, index) => index.toString()}   
        />
      </View>
    );
  }
}

const styles= StyleSheet.create({
  info:{
  flex:1,
  width: 370
  },
  container: {
    flex: 1,
    justifyContent: 'center',
    padding: 20
  },
  textStyle: {
      fontSize: 21,
      padding: 5,
    },
  questionHeading: {
      fontWeight: 'bold',
      fontStyle: 'italic',
      fontSize: 27,
      textDecorationLine: 'underline',
  }, 
  optionHeading: {
    fontWeight: 'bold',
    fontSize: 23,
    textDecorationLine: 'underline',
    }, 
})