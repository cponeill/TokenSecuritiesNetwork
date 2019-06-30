import React, { Component } from 'react'
import { Button, Card, Form, TextArea } from 'semantic-ui-react'
import TokenSecuritiesContract from '../build/contracts/TokenSecurities.json'
import getWeb3 from './utils/getWeb3'

class CreateToken extends Component {
	constructor(props) {
		super(props)

		this.state = {
			name: '',
			symbol: '',
			price: 0,
			web3: null
		}

		this.nameChange = this.nameChange.bind(this)
		this.symbolChange = this.symbolChange.bind(this)
		this.priceChange = this.priceChange.bind(this)
		this.handleSubmit = this.handleSubmit.bind(this)
	}

  componentWillMount() {
    // Get network provider and web3 instance.
    // See utils/getWeb3 for more info.

    getWeb3
    .then(results => {
      this.setState({
        web3: results.web3
      })

      // Instantiate contract once web3 provided.
    })
    .catch(() => {
      console.log('Error finding web3.')
    })
  }

  nameChange(event) {
  	event.preventDefault()

  	this.setState({
  		name: event.target.value,
  	})
  }

  symbolChange(event) {
  	event.preventDefault()

  	this.setState({
  		symbol: event.target.value,
  	})
  }

  priceChange(event) {
  	event.preventDefault()

  	this.setState({
  		price: event.target.value,
  	})
  }

  handleSubmit(event) {

    const contract = require('truffle-contract')
    const tokenSecurities = contract(TokenSecuritiesContract)
    tokenSecurities.setProvider(this.state.web3.currentProvider)

    // Declaring this for later so we can chain functions on SimpleStorage.
    var tokenSecuritiesInstance

    this.state.web3.eth.getAccounts((error, accounts) => {
    	tokenSecurities.deployed().then((instance) => {
    		tokenSecuritiesInstance = instance

    		return tokenSecuritiesInstance.mint(this.state.name, this.state.symbol, this.state.price, { from: accounts[0] })
    	}).then((result) => {
    		var getResult = tokenSecuritiesInstance.getSecurity(0)
    		getResult.then((result) => {
    			this.setState({
    				name: this.state.name,
    				synbol: this.state.symbol,
    				price: this.state.price,
    			})
    		})
    		console.log("Name: " + this.state.name)
    		console.log(this.state.symbol)
    		console.log(this.state.price)
    	})
    })
  }



	render() {
		return (
			<Form>
				<Form.Group width='equal'>
					<Form.Input fluid label='enter token name' onChange={this.nameChange} />
					<Form.Input fluid label='enter token symbol' onChange={this.symbolChange} />
					<Form.Input fluid label='enter token price' onChange={this.priceChange} />
				</Form.Group>
				<Button onClick={this.handleSubmit}>
					Enter name
				</Button>
				<Card>
					<Card.Content>
						<Card.Header>
							{this.state.name}
						</Card.Header>
					</Card.Content>
				</Card>
			</Form>
		)
	}
}

export default CreateToken