# ─────────────────────────────────────────────────────────────────────────────
# Makefile — SIME v2 (Flutter)
# Génération d'APK / AAB de release et utilitaires de build.
# Usage : `make <cible>` (ex. `make apk`). `make` ou `make help` liste tout.
# ─────────────────────────────────────────────────────────────────────────────

# Binaire Flutter (surchargeable : `make apk FLUTTER=fvm flutter`)
FLUTTER ?= flutter

# Options passées aux builds (ex. `make apk DEFINES="--dart-define=ENV=prod"`)
DEFINES ?=

# Chemins de sortie
APK_OUT     := build/app/outputs/flutter-apk/app-release.apk
AAB_OUT     := build/app/outputs/bundle/release/app-release.aab
SPLIT_DIR   := build/app/outputs/flutter-apk

.DEFAULT_GOAL := help

.PHONY: help doctor clean get apk apk-split aab release install run-release size

help: ## Affiche cette aide
	@echo "SIME v2 — cibles disponibles :"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) \
	  | sort \
	  | awk 'BEGIN{FS=":.*?## "}{printf "  \033[36m%-14s\033[0m %s\n", $$1, $$2}'

doctor: ## Vérifie l'installation Flutter / toolchain
	$(FLUTTER) doctor -v

clean: ## Nettoie les artefacts de build
	$(FLUTTER) clean

get: ## Récupère les dépendances (pub get)
	$(FLUTTER) pub get

apk: get ## Génère l'APK de release (fat APK, toutes ABIs)  ← cible principale
	$(FLUTTER) build apk --release $(DEFINES)
	@echo ""
	@echo "✅ APK release : $(APK_OUT)"
	@ls -lh $(APK_OUT) 2>/dev/null || true

apk-split: get ## Génère un APK release par ABI (armeabi-v7a, arm64-v8a, x86_64)
	$(FLUTTER) build apk --release --split-per-abi $(DEFINES)
	@echo ""
	@echo "✅ APKs par ABI dans : $(SPLIT_DIR)"
	@ls -lh $(SPLIT_DIR)/*-release.apk 2>/dev/null || true

aab: get ## Génère l'App Bundle (.aab) pour le Play Store
	$(FLUTTER) build appbundle --release $(DEFINES)
	@echo ""
	@echo "✅ App Bundle : $(AAB_OUT)"
	@ls -lh $(AAB_OUT) 2>/dev/null || true

release: clean apk ## Build propre complet : clean + get + apk

install: ## Installe l'APK release sur l'appareil branché
	$(FLUTTER) install --release

run: ## Lance l'app en mode debug sur l'appareil branché
	$(FLUTTER) run $(DEFINES)

run-release: ## Lance l'app en mode release sur l'appareil branché
	$(FLUTTER) run --release $(DEFINES)

size: ## Analyse la taille de l'APK release
	$(FLUTTER) build apk --release --analyze-size $(DEFINES)
