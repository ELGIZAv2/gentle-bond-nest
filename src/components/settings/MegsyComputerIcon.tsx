// Megsy OS icon — uses the official brand icon asset
import megsyOsIcon from "@/assets/megsy-os-logo.png";

type Props = {
  className?: string;
  alt?: string;
};

export const MegsyComputerIcon = ({ className, alt = "Megsy OS" }: Props) => (
  <img
    src={megsyOsIcon}
    alt={alt}
    className={className}
    loading="lazy"
    width={64}
    height={64}
    draggable={false}
  />
);

export default MegsyComputerIcon;
