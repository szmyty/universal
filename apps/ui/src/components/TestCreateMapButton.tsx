import { useCreateMapMutation } from "@universal/hooks/maps";
import Button from "@universal/components/Button";

const TestCreateMapButton = () => {
    const { mutate, isPending } = useCreateMapMutation();

    const handleCreate = () => {
        const map = {
            name: `TestMap-${Date.now()}`,
            description: "Auto-generated for test",
            state: JSON.stringify({ foo: "bar" }), // Replace with Kepler state later
        };

        mutate(map);
    };

    return (
        <Button onClick={handleCreate} disabled={isPending}>
            {isPending ? "Saving..." : "Create Test Map"}
        </Button>
    );
};

export default TestCreateMapButton;
