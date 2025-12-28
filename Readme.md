# 🎮 Mastermind Game

[![CI](https://github.com/rifah07/mastermind/actions/workflows/ci.yml/badge.svg)](https://github.com/YOUR_USERNAME/mastermind/actions/workflows/ci.yml)
[![Ruby Version](https://img.shields.io/badge/ruby-3.2%2B-red.svg)](https://www.ruby-lang.org)

A web-based implementation of the classic Mastermind code-breaking game built with Ruby and Sinatra.

**🌐 Live Demo:** [https://mastermind-06j2.onrender.com/](https://mastermind-06j2.onrender.com/)

---

## 🎯 Game Modes

### 1. You Guess (Player Mode)
- Computer generates a secret code of 4 colors
- You have 12 turns to crack it
- Use dropdown menus to select colors
- Get feedback: **Exact** (right color, right position) | **Partial** (right color, wrong position)

### 2. Computer Guesses - Random Strategy
- You think of a secret code
- Computer guesses randomly and learns from your feedback
- Watch as possibilities narrow down

### 3. Computer Guesses - Knuth's Algorithm
- Computer uses Donald Knuth's optimal minimax algorithm
- Cracks any code in 5 turns or fewer
- Demonstrates AI problem-solving

---

## 🚀 Quick Start

```bash
# Clone the repository
git clone https://github.com/rifah07/Mastermind.git
cd Mastermind

# Install dependencies
bundle install

# Run the app
ruby app.rb

# Visit http://localhost:4567
```

---

## 📖 How to Play

**Available Colors:** red, green, blue, orange, yellow, purple

**Rules:**
- Secret code has 4 colors
- Colors can repeat
- 12 turns maximum

**Feedback:**
- ✓ **Exact Match**: Correct color in correct position
- ◐ **Partial Match**: Correct color in wrong position

**Example:**
```
Secret:  red, blue, green, yellow
Guess:   red, green, blue, orange
Feedback: 1 exact (red), 2 partial (blue, green)
```

---

## 🧪 Testing

```bash
# Run tests
bundle exec rspec

# Run with details
bundle exec rspec --format documentation
```

**Test Coverage:**
- Exact match counting
- Partial match counting
- Duplicate color handling
- Array mutation prevention

---

## 🏗️ Project Structure

```
mastermind/
├── app.rb                  # Main Sinatra application
├── mastermind.rb           # Player mode logic
├── mastermind_host.rb      # Host mode with random AI
├── mastermind_knuth.rb     # Host mode with Knuth's algorithm
├── views/                  # ERB templates
│   ├── layout.erb          # HTML layout
│   ├── index.erb           # Home page
│   ├── player.erb          # Player mode (with dropdowns)
│   └── host.erb            # Host mode
├── spec/                   # RSpec tests
│   ├── mastermind_spec.rb
│   └── spec_helper.rb
├── config/
│   └── puma.rb             # Web server config
├── .github/workflows/
│   ├── ci.yml              # GitHub Actions CI
    └── cd.yml              # GitHub Actions CD
├── config.ru               # Rack configuration
└── Gemfile                # Dependencies
```

---

## 🧠 Knuth's Algorithm

Donald Knuth's algorithm guarantees solving any Mastermind code in **5 moves or fewer**:

1. **Initial Guess**: Always `red, red, blue, blue`
2. **Minimax Strategy**: Each guess minimizes worst-case remaining possibilities
3. **Smart Filtering**: Eliminates codes that don't match feedback
4. **Optimal Play**: Average 4.5 turns to solve

---

## 🌐 Deployment

### Deploy to Render

1. Push code to GitHub
2. Sign up at [render.com](https://render.com)
3. Create new Web Service
4. Connect your repository
5. Render auto-detects `render.yaml`

**Environment Variables:**
- `SESSION_SECRET`: (auto-generated)

---

## 🛠️ Technologies

- **Ruby 3.4.4** - Core logic
- **Sinatra 4.2.1** - Web framework
- **RSpec** - Testing
- **Puma** - Web server
- **Render** - Hosting

---

## 🤝 Contributing

1. Fork the repository
2. Create feature branch (`git checkout -b feature/awesome`)
3. Commit changes (`git commit -m 'Add feature'`)
4. Push to branch (`git push origin feature/awesome`)
5. Open Pull Request

---

## 📜 License

This project is open source and available under the MIT License.

---

## 🙏 Acknowledgments

- **Donald Knuth** - For the optimal Mastermind algorithm
- **Mordecai Meirowitz** - For inventing Mastermind (1970)
- **Ruby & Sinatra communities** - For excellent tools

---

**Enjoy playing Mastermind! 🎉**

For issues or questions, open an issue on GitHub.