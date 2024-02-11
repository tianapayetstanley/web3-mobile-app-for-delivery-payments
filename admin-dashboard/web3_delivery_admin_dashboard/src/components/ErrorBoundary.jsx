import React from 'react'


class ErrorBoundary extends React.Component {
  constructor(props) {
    super(props)
    this.state = { hasError: false, error: null }
  }

  static getDerivedStateFromError(error) {
    // Update state so the next render will show the fallback UI.
    return { hasError: true, error: error }
  }

  render() {
    if (this.state.hasError) {
      // You can render any custom fallback UI
      return (
        <div className="min-h-screen bg-teal-400 hero">
          <div className="max-w-md p-6 mx-auto text-center bg-white rounded-lg hero-content">
            <div className="max-w-md">
              <h1 className="text-4xl">Error occured</h1>
              <p className="py-6">
                {this.state.error?.message.includes('Attempt to get default algod configuration')
                  ? 'Please make sure to set up your environment variables correctly. Create a .env file based on .env.template and fill in the required values. This controls the network and credentials for connections with Algod and Indexer.'
                  : this.state.error?.message}
              </p>
            </div>
          </div>
        </div>
      )
    }

    // eslint-disable-next-line react/prop-types
    return this.props.children
  }
}

export default ErrorBoundary
