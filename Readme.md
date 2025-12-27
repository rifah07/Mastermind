# 🎮 Mastermind Game

A web-based implementation of the classic Mastermind code-breaking game built with Ruby and Sinatra.

## 📋 Table of Contents

- [Game Modes](#-game-modes)
- [Features](#-features)
- [Quick Start](#-quick-start)
- [How to Play](#-how-to-play)
- [Project Structure](#️-project-structure)
- [Knuth's Algorithm](#-knuths-algorithm-explained)
- [Code Highlights](#-code-highlights)
- [Development & Testing](#-development--testing)
- [CI/CD Pipeline](#-cicd-pipeline)
- [Deployment](#-manual-deployment-to-render)
- [Contributing](#-contributing)
- [License](#-license)

---

### 1. You Guess (Player Mode)
- Computer generates a secret code
- You have 12 turns to crack it
- Receive feedback on each guess

### 2. Computer Guesses - Random Strategy
- You create the secret code
- Computer guesses randomly
- Filters possibilities based on your feedback

### 3. Computer Guesses - Knuth's Algorithm
- You create the secret code
- Computer uses optimal minimax strategy
- Typically cracks codes in 5 turns or less

## 🎨 Features

- **3 Distinct Game Modes**: Play as guesser or host
- **Smart AI**: Implements Knuth's five-guess algorithm
- **Beautiful UI**: Modern, responsive web interface
- **Game History**: Track all guesses and feedback
- **Session Management**: Maintains game state across requests

## 🚀 Quick Start

### Prerequisites

- Ruby 3.0 or higher
- Bundler

### Installation

```bash
# Clone the repository
git clone https://github.com/rifah07/Mastermind.git
cd Mastermind

# Install dependencies
bundle install

# Run the app
ruby app.rb
```

Visit `http://localhost:4567` in your browser.

## 📖 How to Play

### Game Rules

1. The secret code consists of 4 colors
2. Available colors: red, green, blue, orange, yellow, purple
3. Colors can repeat in the code
4. You have 12 turns maximum

### Feedback System

- **Exact Match** (✓): Correct color in the correct position
- **Partial Match** (◐): Correct color in the wrong position

### Example

- **Secret Code**: `red, blue, green, yellow`
- **Your Guess**: `red, green, blue, orange`
- **Feedback**: 1 exact (red), 2 partial (blue and green)

## 🏗️ Project Structure

```
mastermind-game/
├── app.rb                 # Sinatra routes and game logic
├── mastermind.rb          # Player mode game class
├── mastermind_host.rb     # Host mode with random guessing
├── mastermind_knuth.rb    # Host mode with Knuth's algorithm
├── views/
│   ├── layout.erb         # HTML layout
│   ├── index.erb          # Home page
│   ├── player.erb         # Player mode interface
│   └── host.erb           # Host mode interface
├── config.ru              # Rack configuration
├── Gemfile                # Dependencies
└── render.yaml            # Deployment configuration
```

## 🧠 Knuth's Algorithm

The Knuth mode implements Donald Knuth's five-guess algorithm:

1. **Initial Guess**: Always starts with `red, red, blue, blue`
2. **Minimax Strategy**: Chooses each guess to minimize the worst-case number of remaining possibilities
3. **Efficient Filtering**: Rapidly narrows down the solution space
4. **Optimal Performance**: Guarantees solution in 5 guesses or fewer

## 🚀 CI/CD Pipeline

This project includes **complete CI/CD automation** with GitHub Actions.

### ✅ What's Included

| Workflow | File | Purpose | Trigger        |
|----------|------|---------|----------------|
| **CI** (Continuous Integration) | `.github/workflows/ci.yml` | Run tests automatically | Every push/PR  |
| **CD** (Continuous Deployment) | `.github/workflows/cd.yml` | Deploy to Render automatically | Push to master |

### Continuous Integration (CI)

The CI pipeline runs on every push and pull request:

**Tests on multiple Ruby versions:**
- ✅ Ruby 3.2
- ✅ Ruby 3.3

**What it does:**
- Installs dependencies (`bundle install`)
- Runs RSpec test suite (`bundle exec rspec`)
- Validates Ruby syntax
- Optional: Runs Rubocop linting

**Workflow triggers:**
- Push to `master` or `develop` branches
- Pull requests to `master` or `develop` branches

**File location:** `.github/workflows/ci.yml`

### Continuous Deployment (CD)

The CD pipeline automatically deploys to Render on main branch updates:

**What it does:**
- Triggers Render deployment via API
- Waits for deployment to complete
- Performs health check on live site (https://mastermind-06j2.onrender.com/)
- Reports deployment status

**Workflow triggers:**
- Push to `master` branch (automatic)
- Manual trigger via GitHub Actions UI

**File location:** `.github/workflows/cd.yml`

### Setting Up CI/CD

1. **Add GitHub Secrets** (Settings → Secrets → Actions):
   ```
   RENDER_API_KEY: Your Render API key
   RENDER_SERVICE_ID: Your Render service ID
   ```

2. **Get Render API Key**:
    - Go to Render Dashboard → Account Settings
    - Create a new API key
    - Copy and add to GitHub secrets

3. **Get Render Service ID**:
    - Go to your service on Render
    - Copy the service ID from the URL or settings
    - Add to GitHub secrets

4. **Commit workflow files**:
   ```bash
   git add .github/workflows/
   git commit -m "Add CI/CD pipelines"
   git push origin main
   ```

### CI/CD Status

View build status in the GitHub Actions tab. Badges at the top of this README show current CI/CD status.

### Deployment Flow

```
Code Push → GitHub → CI Tests → ✅ Pass → CD Trigger → Render Deploy → Live Site
                                   ❌ Fail → Notify Developer
```

### Deploy to Render

1. Push your code to GitHub
2. Sign up at [render.com](https://render.com)
3. Create a new Web Service
4. Connect your GitHub repository


## 🛠️ Technologies Used

- **Ruby**: Core game logic
- **Sinatra**: Lightweight web framework
- **ERB**: Templating engine
- **Puma**: Web server
- **Render**: Hosting platform

## 📝 Development & Testing

### Running Tests

This project includes comprehensive RSpec tests:

```bash
# Install dependencies
bundle install

# Run all tests
bundle exec rspec
```

### Test Coverage

Current test suite includes:

- **Exact match counting**: Validates correct color in correct position
- **Partial match counting**: Validates correct color in wrong position
- **Array mutation prevention**: Ensures guess arrays aren't modified
- **Duplicate color handling**: Tests edge cases with repeated colors

Example test:

```ruby
RSpec.describe Mastermind do
  let(:game) { Mastermind.new(4, 12) }
  
  before do
    game.instance_variable_set(:@secret_code, %w[red blue green yellow])
  end
  
  it 'counts exact matches correctly' do
    exact, partial = game.send(:check_guess, %w[red blue green yellow])
    expect(exact).to eq(4)
    expect(partial).to eq(0)
  end
  
  it 'counts partial matches correctly' do
    exact, partial = game.send(:check_guess, %w[blue red yellow green])
    expect(exact).to eq(0)
    expect(partial).to eq(4)
  end
  
  it 'does not mutate the guess array' do
    guess = %w[red blue green yellow]
    game.send(:check_guess, guess)
    expect(guess).to eq(%w[red blue green yellow])
  end
end
```


### Code Structure

- `check_guess`: Validates guess against secret code with proper duplicate handling
- `serialize/deserialize`: Handles session state management using pipe-delimited strings
- `find_best_guess_minimax`: Implements Knuth's minimax algorithm
- **RSpec Tests**: Comprehensive test coverage in `spec/` directory
- **Dropdown Selectors**: User-friendly color selection interface

## 🤝 Contributing

Contributions are welcome! Feel free to:

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Submit a pull request

## 📜 License

This project is open source and available under the MIT License.

## 🎓 Learning Resources

- [Mastermind Game Rules](https://en.wikipedia.org/wiki/Mastermind_(board_game))
- [Knuth's Algorithm Paper](https://www.cs.uni.edu/~wallingf/teaching/cs3530/resources/knuth-mastermind.pdf)
- [Sinatra Documentation](http://sinatrarb.com/)

## 📚 Author

Created with ❤️ by Rifah Sajida Deya

## 🙏 Acknowledgments

- Donald Knuth for the optimal algorithm
- The Mastermind board game creators
- Ruby and Sinatra communities

---

**Enjoy playing Mastermind! 🎉**