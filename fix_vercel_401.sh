#!/bin/bash

# Script pour corriger l'erreur 401 Vercel
echo "🔧 Fixing Vercel 401 error..."

# Couleurs pour les logs
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

show_step() {
    echo -e "${BLUE}📋 $1${NC}"
}

show_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

show_error() {
    echo -e "${RED}❌ $1${NC}"
}

show_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

# Étape 1: Vérifier le statut actuel
show_step "Checking current deployment status..."
vercel ls

# Étape 2: Créer un nouveau vercel.json sans protection
show_step "Creating new vercel.json without protection..."

cat > vercel.json << 'EOF'
{
  "version": 2,
  "buildCommand": "echo 'Build completed'",
  "outputDirectory": "web",
  "installCommand": "echo 'Install completed'",
  "framework": null,
  "public": true,
  "rewrites": [
    {
      "source": "/flutter_bootstrap.js",
      "destination": "/flutter_bootstrap.js"
    },
    {
      "source": "/main.dart.js",
      "destination": "/main.dart.js"
    },
    {
      "source": "/flutter.js",
      "destination": "/flutter.js"
    },
    {
      "source": "/flutter_service_worker.js",
      "destination": "/flutter_service_worker.js"
    },
    {
      "source": "/version.json",
      "destination": "/version.json"
    },
    {
      "source": "/assets/(.*)",
      "destination": "/assets/$1"
    },
    {
      "source": "/icons/(.*)",
      "destination": "/icons/$1"
    },
    {
      "source": "/canvaskit/(.*)",
      "destination": "/canvaskit/$1"
    },
    {
      "source": "/manifest.json",
      "destination": "/manifest.json"
    },
    {
      "source": "/favicon.png",
      "destination": "/favicon.png"
    },
    {
      "source": "/(.*)",
      "destination": "/index.html"
    }
  ],
  "headers": [
    {
      "source": "/(.*)",
      "headers": [
        {
          "key": "Access-Control-Allow-Origin",
          "value": "*"
        },
        {
          "key": "Access-Control-Allow-Methods",
          "value": "GET, POST, PUT, DELETE, OPTIONS"
        },
        {
          "key": "Access-Control-Allow-Headers",
          "value": "Content-Type, Authorization"
        }
      ]
    },
    {
      "source": "/main.dart.js",
      "headers": [
        {
          "key": "Cache-Control",
          "value": "public, max-age=31536000, immutable"
        }
      ]
    },
    {
      "source": "/flutter_bootstrap.js",
      "headers": [
        {
          "key": "Cache-Control",
          "value": "public, max-age=31536000, immutable"
        }
      ]
    },
    {
      "source": "/assets/(.*)",
      "headers": [
        {
          "key": "Cache-Control",
          "value": "public, max-age=31536000, immutable"
        }
      ]
    }
  ]
}
EOF

show_success "New vercel.json created"

# Étape 3: S'assurer que le build est prêt
show_step "Ensuring build is ready..."

if [ ! -d "web" ]; then
    show_warning "Web directory not found. Running build..."
    ./deploy_vercel_complete.sh
else
    show_success "Web directory exists"
fi

# Étape 4: Déployer avec les nouvelles configurations
show_step "Deploying with new configuration..."

# Déployer avec l'option --public
vercel --prod --public

if [ $? -eq 0 ]; then
    show_success "Deployment completed!"
    
    # Afficher les instructions
    echo ""
    echo -e "${GREEN}🎉 Deployment completed!${NC}"
    echo ""
    echo -e "${YELLOW}🔧 If you still get 401 errors:${NC}"
    echo "1. Go to https://vercel.com/dashboard"
    echo "2. Select your project"
    echo "3. Go to Settings → Security"
    echo "4. Disable 'Deployment Protection'"
    echo "5. Or set it to 'No Protection'"
    echo ""
    echo -e "${BLUE}📱 Test your app:${NC}"
    echo "vercel ls"
    echo "Then open the URL in your browser"
    
else
    show_error "Deployment failed"
    echo ""
    echo -e "${YELLOW}🔧 Manual steps to fix 401:${NC}"
    echo "1. Go to https://vercel.com/dashboard"
    echo "2. Find your project"
    echo "3. Settings → Security → Deployment Protection"
    echo "4. Set to 'No Protection'"
    echo "5. Save and redeploy"
fi 