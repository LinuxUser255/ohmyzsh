#!/usr/bin/env bash
# Benchmark zsh startup time
# Usage: ./benchmark_startup.sh [iterations]

ITERATIONS=${1:-10}
TOTAL=0

echo "📊 Benchmarking zsh startup time..."
echo "Running $ITERATIONS iterations..."
echo ""

for i in $(seq 1 $ITERATIONS); do
    # Use time in milliseconds
    START=$(date +%s%N)
    /usr/bin/zsh -i -c exit
    END=$(date +%s%N)
    
    ELAPSED=$(( (END - START) / 1000000 ))
    TOTAL=$((TOTAL + ELAPSED))
    
    echo "Run $i: ${ELAPSED}ms"
done

AVERAGE=$((TOTAL / ITERATIONS))

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Average startup time: ${AVERAGE}ms"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Performance rating
if [ $AVERAGE -lt 100 ]; then
    echo "🚀 Excellent! Your shell is blazing fast!"
elif [ $AVERAGE -lt 200 ]; then
    echo "✨ Great! Your shell startup is optimized."
elif [ $AVERAGE -lt 400 ]; then
    echo "👍 Good. There's still room for improvement."
else
    echo "⚠️  Slow. Consider reviewing your plugins and config."
fi
