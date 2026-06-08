import { Star } from "lucide-react";

export function PremiumBadge({ className = "" }: { className?: string }) {
  return (
    <span
      className={`inline-flex items-center gap-1 px-2 py-0.5 rounded-full text-xs font-semibold tracking-wide ${className}`}
      style={{ background: "var(--premium)", color: "var(--premium-foreground)" }}
    >
      <Star size={10} fill="currentColor" />
      PREMIUM
    </span>
  );
}
