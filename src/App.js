import React, { Component } from 'react'
import { Form, Button, TextArea } from 'semantic-ui-react'
import CreateToken from '../src/CreateToken'
import TokenSecuritiesContract from '../build/contracts/TokenSecurities.json'
import getWeb3 from './utils/getWeb3'

import './css/oswald.css'
import './css/open-sans.css'
import './css/pure-min.css'
import './App.css'

class App extends Component {

  render() {
    return (
      <div className="App">
        <nav className="navbar pure-menu pure-menu-horizontal">
            <a href="#" className="pure-menu-heading pure-menu-link">Token Network</a>
        </nav>

        <main className="container">
          <div className="pure-g">
            <div className="pure-u-1-1">
              <CreateToken />
            </div>
          </div>
        </main>
      </div>
    );
  }
}

export default App
